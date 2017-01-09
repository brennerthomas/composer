/*
 * IBM Confidential
 * OCO Source Materials
 * IBM Concerto - Blockchain Solution Framework
 * Copyright IBM Corp. 2016
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has
 * been deposited with the U.S. Copyright Office.
 */

'use strict';

const BusinessNetworkDefinition = require('@ibm/concerto-common').BusinessNetworkDefinition;
const ConnectionProfileManager = require('@ibm/concerto-common').ConnectionProfileManager;
const ConnectionProfileStore = require('@ibm/concerto-common').ConnectionProfileStore;
const ConnectionManager = require('../lib/hfcconnectionmanager');
const hfc = require('hfc');
const hfcChain = hfc.Chain;
const hfcEventHub = hfc.EventHub;
const hfcMember = hfc.Member;
const HFCConnection = require('../lib/hfcconnection');
const HFCSecurityContext = require('../lib/hfcsecuritycontext');
const HFCUtil = require('../lib/hfcutil');
const version = require('../package.json').version;

const chai = require('chai');
const should = chai.should();
chai.use(require('chai-as-promised'));
const sinon = require('sinon');
require('sinon-as-promised');

describe('HFCConnection', () => {

    let sandbox;
    let mockConnectionManager;
    let mockChain;
    let mockEventHub;
    let mockMember;
    let mockSecurityContext;
    let connection;
    let mockConnectionProfileManager;
    let mockConnectionProfileStore;

    beforeEach(() => {
        sandbox = sinon.sandbox.create();
        mockConnectionManager = sinon.createStubInstance(ConnectionManager);
        mockConnectionManager.onDisconnect.resolves();
        mockConnectionProfileManager = sinon.createStubInstance(ConnectionProfileManager);
        mockConnectionProfileStore = sinon.createStubInstance(ConnectionProfileStore);

        mockConnectionProfileStore.load.withArgs('testprofile').resolves({
            type: 'hlf',
            networks: {
                testnetwork: '123'
            }
        });

        mockConnectionProfileStore.save.resolves();
        mockConnectionProfileManager.getConnectionProfileStore.returns(mockConnectionProfileStore);

        mockConnectionManager.getConnectionProfileManager.returns(mockConnectionProfileManager);
        mockEventHub = sinon.createStubInstance(hfcEventHub);
        mockMember = sinon.createStubInstance(hfcMember);
        mockChain = sinon.createStubInstance(hfcChain);
        mockChain.getEventHub.returns(mockEventHub);
        mockChain.enroll.callsArgWith(2, null, mockMember);
        mockSecurityContext = sinon.createStubInstance(HFCSecurityContext);
        connection = new HFCConnection(mockConnectionManager, 'testprofile', 'testnetwork', mockChain);
    });

    afterEach(function() {
        sandbox.restore();
    });

    describe('#constructor', () => {

        it('should throw if chain not specified', () => {
            (() => {
                new HFCConnection(mockConnectionManager, 'testprofile', 'testnetwork', null);
            }).should.throw(/chain must be set/);
        });

    });

    describe('#disconnect', function() {

        it('should do nothing if not connected', () => {
            return connection.disconnect();
        });

        it('should notify connection manager', () => {
            return connection.disconnect()
                .then(() => {
                    sinon.assert.calledOnce(mockConnectionManager.onDisconnect);
                });
        });
    });

    describe('#login', function() {

        it('should throw when enrollmentID not specified', function() {
            (function() {
                connection.login(null, 'suchsecret');
            }).should.throw(/enrollmentID not specified/);
        });

        it('should throw when enrollmentSecret not specified', function() {
            (function() {
                connection.login('doge', null);
            }).should.throw(/enrollmentSecret not specified/);
        });

        it('should enroll against the Hyperledger Fabric', function() {

            // Login to the Hyperledger Fabric using the mock hfc.
            let enrollmentID = 'doge';
            let enrollmentSecret = 'suchsecret';
            return connection
                .login('doge', 'suchsecret')
                .then(function(securityContext) {
                    sinon.assert.calledOnce(mockChain.enroll);
                    sinon.assert.calledWith(mockChain.enroll, enrollmentID, enrollmentSecret);
                    sinon.assert.calledOnce(mockChain.setRegistrar);
                    sinon.assert.calledWith(mockChain.setRegistrar, mockMember);
                    securityContext.should.be.a.instanceOf(HFCSecurityContext);
                    securityContext.getEnrolledMember().should.equal(mockMember);
                    securityContext.getEventHub().should.equal(mockEventHub);
                });

        });

        it('should handle an error from enrolling against the Hyperledger Fabric', function() {

            // Set up the hfc mock.
            mockChain.enroll.onFirstCall().callsArgWith(2, new Error('failed to login'), null);

            // Login to the Hyperledger Fabric using the mock hfc.
            let enrollmentID = 'doge';
            let enrollmentSecret = 'suchsecret';
            return connection
                .login(enrollmentID, enrollmentSecret)
                .then(function(securityContext) {
                    throw new Error('should not get here');
                }).catch(function(error) {
                    error.should.match(/failed to login/);
                });

        });

        it('should look for an existing chaincode ID', function() {

            // Login to the Hyperledger Fabric using the mock hfc.
            let enrollmentID = 'doge';
            let enrollmentSecret = 'suchsecret';
            return connection
                .login(enrollmentID, enrollmentSecret)
                .then(function(securityContext) {
                    securityContext.getChaincodeID().should.equal('123');
                });

        });

        it('should throw if the chaincode ID does not exist', function() {

            // Login to the Hyperledger Fabric using the mock hfc.
            mockConnectionProfileStore.load.withArgs('testprofile').resolves({
                type: 'hlf',
                networks: {
                    someothernetwork: '123'
                }
            });
            let enrollmentID = 'doge';
            let enrollmentSecret = 'suchsecret';
            return connection
                .login(enrollmentID, enrollmentSecret)
                .should.be.rejectedWith(/Failed to set chaincode id on security context/);

        });

        it('should throw if the networks section is missing', function() {

            // Login to the Hyperledger Fabric using the mock hfc.
            mockConnectionProfileStore.load.withArgs('testprofile').resolves({
                type: 'hlf'
            });
            let enrollmentID = 'doge';
            let enrollmentSecret = 'suchsecret';
            return connection
                .login(enrollmentID, enrollmentSecret)
                .should.be.rejectedWith(/Failed to set chaincode id on security context/);

        });

        it('should not look for an existing chaincode ID if no business network is specified', () => {

            // Login to the Hyperledger Fabric using the mock hfc.
            connection = new HFCConnection(mockConnectionManager, 'testprofile', null, mockChain);
            let enrollmentID = 'doge';
            let enrollmentSecret = 'suchsecret';
            return connection
                .login(enrollmentID, enrollmentSecret)
                .then(function(securityContext) {
                    should.equal(securityContext.getChaincodeID(), null);
                });

        });

    });

    describe('#deploy', function() {

        it('should perform a security check', () => {
            sandbox.stub(HFCUtil, 'securityCheck');
            sandbox.stub(HFCUtil, 'deployChainCode').resolves({
                chaincodeID: 'muchchaincodeID'
            });
            const businessNetworkStub = sinon.createStubInstance(BusinessNetworkDefinition);
            businessNetworkStub.toArchive.resolves(new Buffer([0x00, 0x01, 0x02]));
            businessNetworkStub.getName.returns('testnetwork');
            sandbox.stub(connection, 'ping').resolves();
            mockConnectionProfileStore.load.withArgs('testprofile').resolves({
                type: 'hlf',
                networks: {
                }
            });
            return connection.deploy(mockSecurityContext, true, businessNetworkStub)
                .then(() => {
                    sinon.assert.calledOnce(HFCUtil.securityCheck);
                    sinon.assert.calledOnce(mockConnectionProfileStore.save);
                });
        });

        it('should deploy the Concerto chain-code to the Hyperledger Fabric', function() {

            // Set up the responses from the chain-code.
            sandbox.stub(HFCUtil, 'deployChainCode').resolves({
                chaincodeID: 'muchchaincodeID'
            });
            sandbox.stub(connection, 'ping').resolves();
            const businessNetworkStub = sinon.createStubInstance(BusinessNetworkDefinition);
            businessNetworkStub.toArchive.resolves(new Buffer([0x00, 0x01, 0x02]));
            businessNetworkStub.getName.returns('testnetwork');
            mockConnectionProfileStore.load.withArgs('testprofile').resolves({
                type: 'hlf'
            });

            return connection
                .deploy(mockSecurityContext, true, businessNetworkStub)
                .then(function() {

                    // Check that the query was made successfully.
                    sinon.assert.calledOnce(HFCUtil.deployChainCode);
                    sinon.assert.calledWith(HFCUtil.deployChainCode, mockSecurityContext, 'concerto', 'init', ['AAEC']);
                    sinon.assert.calledOnce(connection.ping);
                    sinon.assert.calledWith(connection.ping, mockSecurityContext);

                    // Check that the security context was updated correctly.
                    sinon.assert.calledOnce(mockSecurityContext.setChaincodeID);
                    sinon.assert.calledWith(mockSecurityContext.setChaincodeID, 'muchchaincodeID');

                    // check the profile store was updated
                    sinon.assert.calledOnce(mockConnectionProfileStore.save);
                });
        });

        it('should not deploy a second time the Concerto chain-code to the Hyperledger Fabric', function() {

            // Set up the responses from the chain-code.
            sandbox.stub(HFCUtil, 'deployChainCode').resolves({
                chaincodeID: 'secondChaincodeID'
            });
            sandbox.stub(connection, 'ping').resolves();
            const businessNetworkStub = sinon.createStubInstance(BusinessNetworkDefinition);
            businessNetworkStub.getName.returns('testnetwork');
            businessNetworkStub.toArchive.resolves(new Buffer([0x00, 0x01, 0x02]));

            return connection
                .deploy(mockSecurityContext, true, businessNetworkStub)
                .then(function(assetRegistries) {
                    throw new Error('should not get here');
                }).catch(function(error) {
                    error.should.match(/already contains the deployed network testnetwork/);
                });
        });

        it('should handle an error deploying the Concerto chain-code the Hyperledger Fabric', function() {

            // Set up the responses from the chain-code.
            sandbox.stub(HFCUtil, 'deployChainCode').rejects(
                new Error('failed to deploy chain-code')
            );

            const businessNetworkStub = sinon.createStubInstance(BusinessNetworkDefinition);
            businessNetworkStub.toArchive.resolves(new Buffer([0x00, 0x01, 0x02]));

            return connection
                .deploy(mockSecurityContext, true, businessNetworkStub)
                .then(function(assetRegistries) {
                    throw new Error('should not get here');
                }).catch(function(error) {
                    error.should.match(/failed to deploy chain-code/);
                });

        });

    });

    describe('#undeploy', function() {

        it('should be able to undeploy without deploying', () => {
            sandbox.stub(HFCUtil, 'securityCheck');
            sandbox.stub(HFCUtil, 'deployChainCode').resolves({
                chaincodeID: 'muchchaincodeID'
            });
            sandbox.stub(HFCUtil, 'invokeChainCode').resolves();
            mockConnectionProfileStore.load.withArgs('testprofile').resolves({
                type: 'hlf'
            });

            const businessNetworkStub = sinon.createStubInstance(BusinessNetworkDefinition);
            businessNetworkStub.toArchive.resolves(new Buffer([0x00, 0x01, 0x02]));
            connection = new HFCConnection(mockConnectionManager, 'testprofile', null, mockChain);
            sandbox.stub(connection, 'ping').resolves();

            return connection.undeploy(mockSecurityContext, 'testnetwork')
              .then(() => {
                  sinon.assert.calledOnce(HFCUtil.securityCheck);
                  sinon.assert.notCalled(mockConnectionProfileStore.save);
              });
        });

        it('should be able to deploy followed by undeploy', () => {
            sandbox.stub(HFCUtil, 'securityCheck');
            sandbox.stub(HFCUtil, 'deployChainCode').resolves({
                chaincodeID: 'muchchaincodeID'
            });
            sandbox.stub(HFCUtil, 'invokeChainCode').resolves();

            const businessNetworkStub = sinon.createStubInstance(BusinessNetworkDefinition);
            businessNetworkStub.toArchive.resolves(new Buffer([0x00, 0x01, 0x02]));
            connection = new HFCConnection(mockConnectionManager, 'testprofile', null, mockChain);
            sandbox.stub(connection, 'ping').resolves();

            return connection.deploy(mockSecurityContext, true, businessNetworkStub)
                .then(() => {
                    sinon.assert.calledOnce(HFCUtil.securityCheck);
                    sinon.assert.calledOnce(mockConnectionProfileStore.save);
                })
                .then(() => {
                    return connection.undeploy(mockSecurityContext, 'testnetwork');
                })
                .then(() => {
                    sinon.assert.calledTwice(HFCUtil.securityCheck);
                    sinon.assert.calledTwice(mockConnectionProfileStore.save);
                });
        });

        it('should handle an error undeploying a business network definition', function() {

        // Set up the responses from the chain-code.
            sandbox.stub(HFCUtil, 'invokeChainCode').rejects(
            new Error('failed to update business network definition')
        );

            return connection
            .undeploy(mockSecurityContext, 'testnetwork')
            .then(function(assetRegistries) {
                throw new Error('should not get here');
            }).catch(function(error) {
                error.should.match(/failed to update/);
            });
        });

        it('should require a business network id', function() {

            connection = new HFCConnection(mockConnectionManager, 'testprofile', null, mockChain);

            (function() {
                return connection
                .undeploy(mockSecurityContext, null)
                .then(() => {
                    throw new Error('should not get here');
                });
            }).should.throw(/Business network id must be specified/);
        });
    });

    describe('#update', function() {

        it('should perform a security check', () => {
            sandbox.stub(HFCUtil, 'securityCheck');
            sandbox.stub(HFCUtil, 'invokeChainCode').resolves();
            const businessNetworkStub = sinon.createStubInstance(BusinessNetworkDefinition);
            businessNetworkStub.toArchive.resolves(new Buffer([0x00, 0x01, 0x02]));

            return connection.update(mockSecurityContext, businessNetworkStub)
            .then(() => {
                sinon.assert.calledOnce(HFCUtil.securityCheck);
            });
        });

        it('should update a BusinessNetworkDefinition', function() {

        // Set up the responses from the chain-code.
            sandbox.stub(HFCUtil, 'invokeChainCode').resolves();
            const businessNetworkStub = sinon.createStubInstance(BusinessNetworkDefinition);
            businessNetworkStub.toArchive.resolves(new Buffer([0x00, 0x01, 0x02]));

            return connection
            .update(mockSecurityContext, businessNetworkStub)
            .then(function() {

                // Check that the query was made successfully.
                sinon.assert.calledOnce(HFCUtil.invokeChainCode);
                sinon.assert.calledWith(HFCUtil.invokeChainCode, mockSecurityContext, 'updateBusinessNetwork', ['AAEC']);
            });
        });

        it('should handle an error updating a business network definition', function() {

        // Set up the responses from the chain-code.
            sandbox.stub(HFCUtil, 'invokeChainCode').rejects(
            new Error('failed to update business network definition')
        );
            const businessNetworkStub = sinon.createStubInstance(BusinessNetworkDefinition);
            businessNetworkStub.toArchive.resolves(new Buffer([0x00, 0x01, 0x02]));

            return connection
            .update(mockSecurityContext, businessNetworkStub)
            .then(function() {
                throw new Error('should not get here');
            }).catch(function(error) {
                error.should.match(/failed to update/);
            });
        });
    });

    describe('#ping', () => {

        it('should perform a security check', () => {
            sandbox.stub(HFCUtil, 'securityCheck');
            sandbox.stub(HFCUtil, 'queryChainCode').resolves(Buffer.from(JSON.stringify({
                version: version
            })));
            return connection.queryChainCode(mockSecurityContext, 'myfunc', ['arg1', 'arg2'])
            .then(() => {
                sinon.assert.calledOnce(HFCUtil.securityCheck);
            });
        });

        it('should resolve if the package and chaincode version match', () => {

        // Set up the responses from the chain-code.
            sandbox.stub(HFCUtil, 'queryChainCode').resolves(Buffer.from(JSON.stringify({
                version: version
            })));

        // Invoke the ping function.
            return connection
            .ping(mockSecurityContext)
            .then((result) => {

                // Check that the query was made successfully.
                sinon.assert.calledOnce(HFCUtil.queryChainCode);
                sinon.assert.calledWith(HFCUtil.queryChainCode, mockSecurityContext, 'ping', []);
                result.should.deep.equal({
                    version: version
                });

            });

        });

        it('should throw an error if the package and chaincode version do not match', () => {

        // Set up the responses from the chain-code.
            sandbox.stub(HFCUtil, 'queryChainCode').resolves(Buffer.from(JSON.stringify({
                version: '2016.12.25'
            })));

        // Invoke the ping function.
            return connection
            .ping(mockSecurityContext)
            .then(function() {
                throw new Error('should not get here');
            }).catch(function(error) {
                error.should.match(/Deployed chain-code \(2016.12.25\) is incompatible with client \(.+?\)/);
            });

        });

    });

    describe('#queryChainCode', () => {

        it('should perform a security check', () => {
            sandbox.stub(HFCUtil, 'securityCheck');
            sandbox.stub(HFCUtil, 'queryChainCode').resolves();
            return connection.queryChainCode(mockSecurityContext, 'myfunc', ['arg1', 'arg2'])
            .then(() => {
                sinon.assert.calledOnce(HFCUtil.securityCheck);
            });
        });

        it('should query the chain code', () => {
            sandbox.stub(HFCUtil, 'securityCheck');
            sandbox.stub(HFCUtil, 'queryChainCode').resolves();
            return connection.queryChainCode(mockSecurityContext, 'myfunc', ['arg1', 'arg2'])
            .then(() => {
                sinon.assert.calledOnce(HFCUtil.queryChainCode);
                sinon.assert.calledWith(HFCUtil.queryChainCode, mockSecurityContext, 'myfunc', ['arg1', 'arg2']);
            });
        });

    });

    describe('#invokeChainCode', () => {

        it('should perform a security check', () => {
            sandbox.stub(HFCUtil, 'securityCheck');
            sandbox.stub(HFCUtil, 'invokeChainCode').resolves();
            return connection.invokeChainCode(mockSecurityContext, 'myfunc', ['arg1', 'arg2'])
                .then(() => {
                    sinon.assert.calledOnce(HFCUtil.securityCheck);
                });
        });

        it('should query the chain code', () => {
            sandbox.stub(HFCUtil, 'securityCheck');
            sandbox.stub(HFCUtil, 'invokeChainCode').resolves();
            return connection.invokeChainCode(mockSecurityContext, 'myfunc', ['arg1', 'arg2'])
                .then(() => {
                    sinon.assert.calledOnce(HFCUtil.invokeChainCode);
                    sinon.assert.calledWith(HFCUtil.invokeChainCode, mockSecurityContext, 'myfunc', ['arg1', 'arg2']);
                });
        });

    });

    describe('#createIdentity', () => {

        it('should perform a security check', () => {
            sandbox.stub(HFCUtil, 'securityCheck');
            sandbox.stub(HFCUtil, 'createIdentity').resolves('suchsecret');
            return connection.createIdentity(mockSecurityContext, 'doge')
                .then(() => {
                    sinon.assert.calledOnce(HFCUtil.securityCheck);
                });
        });

        it('should query the chain code', () => {
            sandbox.stub(HFCUtil, 'securityCheck');
            sandbox.stub(HFCUtil, 'createIdentity').resolves('suchsecret');
            return connection.createIdentity(mockSecurityContext, 'doge')
                .then(() => {
                    sinon.assert.calledOnce(HFCUtil.createIdentity);
                    sinon.assert.calledWith(HFCUtil.createIdentity, mockSecurityContext, 'doge');
                });
        });

    });

    describe('#list', () => {

        it('should list all deployed business networks', () => {
            mockConnectionProfileStore.load.withArgs('testprofile').resolves({
                type: 'hlf',
                networks: {
                    demonetwork: '123',
                    testnetwork: '456'
                }
            });
            return connection.list(mockSecurityContext)
                .should.eventually.be.deep.equal(['demonetwork', 'testnetwork']);
        });

        it('should cope with an empty list of networks', () => {
            mockConnectionProfileStore.load.withArgs('testprofile').resolves({
                type: 'hlf',
                networks: { }
            });
            return connection.list(mockSecurityContext)
                .should.eventually.be.deep.equal([]);
        });

        it('should cope with a missing list of networks', () => {
            mockConnectionProfileStore.load.withArgs('testprofile').resolves({
                type: 'hlf'
            });
            return connection.list(mockSecurityContext)
                .should.eventually.be.deep.equal([]);
        });

    });

});